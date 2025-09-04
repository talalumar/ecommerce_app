import {Router} from "express"
import {
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
} from "../controllers/user.controller.js"
import { verifyJWT } from "../middlewares/auth.middleware.js"

const router = Router()

router.route("/register/verify").post(verifyRegister)
router.route("/register/request").post(requestRegister) 
router.route("/register/resend-otp").post(resendRegisterOtp) 
router.route("/login").post(loginUser)  
router.route("/logout").post(verifyJWT, logoutUser)
router.route("/refresh").post(refreshAccessToken)
router.route("/change-password").post(verifyJWT, changeCurrentPassword)
router.route("/forgot-password/request").post(requestPasswordReset) 
router.route("/forgot-password/verify").post(verifyPasswordReset)
router.route("/forgot-password/reset").post(resetPassword)

export default router