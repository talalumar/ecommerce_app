import { Cart } from "../models/cart.model.js";
import { Product } from "../models/product.model.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";

// Add item to cart
const addToCart = asyncHandler(async (req, res) => {
  const { productId, quantity } = req.body;
  const userId = req.user.id; // from JWT middleware

  if (!productId || !quantity) {
    throw new ApiError(400, "ProductId and quantity are required");
  }

  const product = await Product.findById(productId);
  if (!product) {
    throw new ApiError(404, "Product not found");
  }

  // Check if already in cart
  let cartItem = await Cart.findOne({ userId, productId });

  if (cartItem) {
    cartItem.quantity += quantity;
    await cartItem.save();
  } else {
    cartItem = await Cart.create({
      userId,
      productId,
      quantity,
      price: product.price,
    });
  }

  return res
    .status(201)
    .json(new ApiResponse(201, cartItem, "Product added to cart successfully"));
});

// Get user cart
const getCart = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const cart = await Cart.find({ userId }).populate("productId");

  return res
    .status(200)
    .json(new ApiResponse(200, cart, "Cart fetched successfully"));
});

// Update cart item quantity
const updateCartItem = asyncHandler(async (req, res) => {
  const { cartItemId } = req.params;
  const { quantity } = req.body;
  const userId = req.user.id;

  const cartItem = await Cart.findOne({ _id: cartItemId, userId });
  if (!cartItem) {
    throw new ApiError(404, "Cart item not found");
  }

  if (quantity <= 0) {
    throw new ApiError(400, "Quantity must be at least 1");
  }

  cartItem.quantity = quantity;
  await cartItem.save();

  return res
    .status(200)
    .json(new ApiResponse(200, cartItem, "Cart item updated successfully"));
});

// Remove item from cart
const removeFromCart = asyncHandler(async (req, res) => {
  const { cartItemId } = req.params;
  const userId = req.user.id;

  const cartItem = await Cart.findOne({ _id: cartItemId, userId });
  if (!cartItem) {
    throw new ApiError(404, "Cart item not found");
  }

  await cartItem.deleteOne();

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "Cart item removed successfully"));
});

export { addToCart, getCart, updateCartItem, removeFromCart };
