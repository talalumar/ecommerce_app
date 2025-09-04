import jwt from "jsonwebtoken";
import { ApiError } from "../utils/ApiError.js";
import {User} from "../models/user.model.js";

const verifyJWT = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new ApiError(401, "Unauthorized request: No token provided");
    }

    const token = authHeader.split(" ")[1]; // Extract the token

    // Verify the token
    const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);

    // Find user in DB
    const user = await User.findById(decodedToken._id || decodedToken.id).select(
      "-password -refreshToken"
    );

    if (!user) {
      throw new ApiError(401, "Unauthorized request: User not found");
    }

    req.user = user; // Attach user to request object
    next();
  } catch (error) {
    console.error("JWT verification error:", error.message);
    next(new ApiError(401, "Invalid or expired token"));
  }
};

export { verifyJWT };
