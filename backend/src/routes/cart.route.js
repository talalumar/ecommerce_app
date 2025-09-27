import express from "express";
import { addToCart, getCart, updateCartItem, removeFromCart } from "../controllers/cart.controller.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.post("/add", verifyJWT, addToCart);
router.get("/", verifyJWT, getCart);
router.put("/:cartItemId", verifyJWT, updateCartItem);
router.delete("/:cartItemId", verifyJWT, removeFromCart);

export default router;
