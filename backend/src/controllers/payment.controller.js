import Stripe from "stripe";
import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import dotenv from "dotenv";
import { Order } from "../models/order.model.js";

dotenv.config();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: "2024-06-20",
}); 

// Create PaymentIntent
export const createPaymentIntent = asyncHandler(async (req, res) => {
  const { cartItems } = req.body;
  const userId = req.user._id;

  if (!cartItems || cartItems.length === 0) {
    throw new ApiError(400, "Cart is empty");
  }

  // Calculate total in cents
  const amount = cartItems.reduce(
    (total, item) => total + item.price * item.quantity * 100,
    0
  );

  try {
    // 1. Save pending order first
    const order = await Order.create({
      user: userId,
      products: cartItems.map((item) => ({
        product: item.productId,
        quantity: item.quantity,
      })),
      totalAmount: amount / 100,
      paymentStatus: "pending",
      paymentMethod: "card",
    });

    // 2. Create PaymentIntent and attach orderId to metadata
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: "usd",
      automatic_payment_methods: { enabled: true },
      metadata: {
        orderId: order._id.toString(),
        userId: userId.toString(),
      },
    });

    // 3. Save stripePaymentIntentId to order
    order.stripePaymentIntentId = paymentIntent.id;
    await order.save();

    // 4. Return clientSecret to frontend
    return res.status(200).json({
      clientSecret: paymentIntent.client_secret,
      orderId: order._id,
    });
  } catch (error) {
    console.error("Stripe PaymentIntent error:", error);
    return res.status(500).json({ message: "Failed to create payment intent" });
  }
});


// Stripe Webhook
export const stripeWebhook = asyncHandler(async (req, res) => {
  const sig = req.headers["stripe-signature"];
  let event;

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    console.error("Webhook signature verification failed:", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === "payment_intent.succeeded") {
    const paymentIntent = event.data.object;
    const orderId = paymentIntent.metadata.orderId;


    const updatedOrder = await Order.findByIdAndUpdate(
      orderId,
      { paymentStatus: "paid" },
      { new: true }
    );

  }

  res.status(200).json({ received: true });
});



