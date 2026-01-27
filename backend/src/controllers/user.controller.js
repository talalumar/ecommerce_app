import {asyncHandler} from "../utils/asyncHandler.js"
import {ApiError} from "../utils/ApiError.js"
import {User} from "../models/user.model.js"
import { ApiResponse } from "../utils/ApiResponse.js"
import jwt from "jsonwebtoken"
import { sendOtpEmail } from "../utils/SendOtp.js"
import redis from "../db/redis.js"
import bcrypt from "bcrypt"
import mongoose from "mongoose"


const generateAccessAndRefreshTokens = async(userId) =>
{
    try {
        const user = await User.findById(userId)
        const accessToken = user.generateAccessToken()
        const refreshToken = user.generateRefreshToken()

        user.refreshToken = refreshToken
        await user.save({validateBeforeSave: false})

        return {accessToken, refreshToken}

    } catch (error) {
       throw new ApiError(500, "Something went wrong while generating refresh and access token") 
    }
}

const OTP_TTL = Number(process.env.OTP_EXPIRES_SECONDS || 300);

const requestRegister = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;
  if ([name, email, password].some(f => f?.trim() === "")) {
    throw new ApiError(400, "All fields are required");
  }

  const exists = await User.findOne({ email });
  if (exists) throw new ApiError(409, "User with this email already exists");

  // Hash password BEFORE saving to Redis (so plain password is never stored)
  const hashedPassword = await bcrypt.hash(password, 10);

  // generate 6-digit OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  const key = `register:${email.toLowerCase()}`;
  const payload = JSON.stringify({ name, email: email.toLowerCase(), password: hashedPassword, otp });

  // set with ttl (ex in seconds)
  await redis.set(key, payload, { ex: OTP_TTL });

  // send OTP to user email
  await sendOtpEmail(email, name, otp);

  return res.status(200).json(new ApiResponse(200, null, "OTP sent to email"));
});

const verifyRegister = asyncHandler(async (req, res) => {
  const { email, otp } = req.body;
  if ([email, otp].some(f => f?.trim() === "")) throw new ApiError(400, "Email and OTP are required");

  const key = `register:${email.toLowerCase()}`;
  const data = await redis.get(key);
  if (!data) throw new ApiError(400, "OTP expired or not found. Request a new one.");
 
  if (data.otp !== otp) throw new ApiError(400, "Invalid OTP");

  // ensure user wasn't created in the meantime
  const exists = await User.findOne({ email: data.email });
  if (exists) {
    await redis.del(key);
    throw new ApiError(409, "User already exists");
  }

  // create user with hashed password (we already hashed it)
  const user = await User.create({ name: data.name, email: data.email, password: data.password });

  // cleanup
  await redis.del(key);

  const createdUser = await User.findById(user._id).select("-password -refreshToken");
  return res.status(201).json(new ApiResponse(201, createdUser, "User registered successfully"));
});


const resendRegisterOtp = asyncHandler(async (req, res) => {
  const { email } = req.body;

  if (!email) {
    throw new ApiError(400, "Email is required");
  }

  const key = `register:${email.toLowerCase()}`;
  const storedData = await redis.get(key);

  if (!storedData) {
    throw new ApiError(400, "No pending registration found. Please register again.");
  }

  // Generate new OTP
  const newOtp = Math.floor(100000 + Math.random() * 900000).toString();

  // Update Redis with same data but new OTP
  await redis.set(
    key,
    JSON.stringify({ ...storedData, otp: newOtp }),
    { ex: OTP_TTL } // reset expiry to 5 min
  );

  // Send OTP again
  await sendOtpEmail(email, storedData.name, newOtp); 

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "New OTP sent to email successfully"));
});


const loginUser = asyncHandler(async (req, res) => {
    // req body -> data
    // username or email
    //find the user
    //password check
    //access and referesh token
    //send cookie

    const { email, password } = req.body;

    if(!email){
        throw new ApiError(400, "Email is required");
    }

    //find the user
    const user = await User.findOne({ email });

    if(!user){
        throw new ApiError(404, "User not found");
    }

    //password check
    const isPasswordValid = await user.isPasswordCorrect(password);

    if(!isPasswordValid){
        throw new ApiError(401, "Invalid password");
    }

    const {accessToken, refreshToken} = await generateAccessAndRefreshTokens(user._id)

    const loggedInUser = await User.findById(user._id).select("-password -refreshToken");
  
    return res.status(200)
    .json(new ApiResponse(
        200, 
        {user: loggedInUser, accessToken, refreshToken, role: user.role},
        "User logged in successfully",
    ))
})

const logoutUser = asyncHandler(async (req, res) => {
  const { email } = req.body;

  if (!email) {
    throw new ApiError(400, "Email is required to logout");
  }

  const user = await User.findOne({ email });
  if (!user) {
    throw new ApiError(404, "User not found");
  }

  user.refreshToken = undefined;
  await user.save();

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "User logged out successfully"));
});

const refreshAccessToken = asyncHandler(async (req, res)=> {
    const incomingRefreshToken = req.body.refreshToken

    if(!incomingRefreshToken){
        throw new ApiError(401, "unauthorized request")
    }

    try {
        const decodedToken = jwt.verify(
            incomingRefreshToken, 
            process.env.REFRESH_TOKEN_SECRET
        )
    
        const user = await User.findById(decodedToken?._id)
    
        if(!user){
            throw new ApiError(401, "Invalid Refresh Token")
        }
    
        if(incomingRefreshToken !== user?.refreshToken) {
            throw new ApiError(401, "Refresh token is expired or used")
        }
    
        const {accessToken, refreshToken} = await generateAccessAndRefreshTokens(user._id)
    
        return res.status(200)
        .json( 
            new ApiResponse(
                200,
                {accessToken, refreshToken},
                "Access token refreshed"
            )
        )
    } catch (error) {
        throw new ApiError(401, error?.message || "Invalid Refresh Token")
    }

})

const changeCurrentPassword = asyncHandler(async (req, res) => {
   const {oldPassword, newPassword} = req.body; 

   const user = await User.findById(req.user?._id)
   const isPasswordCorrect = await user.isPasswordCorrect(oldPassword)

   if(!isPasswordCorrect) {
       throw new ApiError(400, "Old password is incorrect")
   }

   user.password = newPassword
   await user.save() 

   return res.status(200).json(new ApiResponse(200, {}, "Password changed successfully"))
})

const requestPasswordReset = asyncHandler(async (req, res) => {
  const { email } = req.body;

  if ([email].some(f => f?.trim() === "")) {
    throw new ApiError(400, " Email is required");
  }

  // Find user
  const user = await User.findOne({ email });
  if (!user) {
    throw new ApiError(404, "User not found with this email");
  }

  // Generate 6-digit OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const payload = JSON.stringify({ otp });

  // Save OTP in Redis with 5 min expiry
  const key = `forgot_otp:${email.toLowerCase()}`;
  await redis.set(key, payload, { ex: OTP_TTL });

  // Send OTP to email
  await sendOtpEmail(email, user.name, otp);

  return res 
    .status(200)
    .json(new ApiResponse(200, {}, "Password reset OTP sent successfully"));
});


const verifyPasswordReset = asyncHandler(async (req, res) => {
  const { email, otp } = req.body;

  if ([email, otp].some(f => f?.trim() === "")) throw new ApiError(400, "Email and OTP are required");

  const key = `forgot_otp:${email.toLowerCase()}`;
  const data = await redis.get(key);
  
  if (!data) {
    throw new ApiError(400, "OTP expired or invalid");
  }
 
  if (data.otp !== otp) {
    throw new ApiError(400, "Invalid OTP");
  }

  // delete OTP so it can't be reused
  await redis.del(key);

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "OTP verified successfully. You can now reset your password."));
});


const resetPassword = asyncHandler(async (req, res) => {
  const { email, newPassword } = req.body;
  
  if (!email || !newPassword) {
    throw new ApiError(400, "Email and new password are required");
  }

  // Find user
  const user = await User.findOne({ email });
  if (!user) {
    throw new ApiError(404, "User not found with this email");
  }

  // Update password
  user.password = newPassword;
  await user.save({ validateBeforeSave: false });

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "Password reset successful"));
});




export { 
    requestRegister,
    verifyRegister, 
    resendRegisterOtp,
    loginUser,
    logoutUser,
    refreshAccessToken,
    changeCurrentPassword,
    requestPasswordReset,
    verifyPasswordReset,
    resetPassword
};