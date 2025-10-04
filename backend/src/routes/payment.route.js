import express from "express";
import { stripeWebhook, createPaymentIntent } from "../controllers/payment.controller.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.post("/create-payment-intent", verifyJWT, createPaymentIntent);

// Stripe Webhook 
router.post("/webhook", express.raw({ type: "application/json" }), stripeWebhook);

export default router;
