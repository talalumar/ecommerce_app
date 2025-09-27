import { Product } from "../models/product.model.js";
import { uploadOnCloudinary } from "../utils/cloudinary.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { v2 as cloudinary } from "cloudinary";

// Create Product
const createProduct = asyncHandler(async (req, res) => {
  const { name, price, description, quantity } = req.body;

  if (!name || !price || !description || !quantity) {
    throw new ApiError(400, "All fields (name, price, description, quantity) are required");
  }

  if (!req.file) {
    throw new ApiError(400, "Product image is required");
  }

  // Upload image to Cloudinary
  const cloudinaryResult = await uploadOnCloudinary(req.file.path);

  if (!cloudinaryResult) {
    throw new ApiError(500, "Image upload failed");
  }

  // Save product in DB
  const product = await Product.create({
    name,
    price,
    description,
    quantity,
    imageUrl: cloudinaryResult.secure_url,
    imagePublicId: cloudinaryResult.public_id,
  });

  return res
    .status(201)
    .json(new ApiResponse(201, product, "Product created successfully"));
});


// Get All Products
const getAllProducts = asyncHandler(async (req, res) => {
  const products = await Product.find().sort({ createdAt: -1 });

  return res
    .status(200)
    .json(new ApiResponse(200, products, "Products fetched successfully"));
});


// Get Single Product
const getProductById = asyncHandler(async (req, res) => {
  const product = await Product.findById(req.params.id);

  if (!product) {
    throw new ApiError(404, "Product not found");
  }

  return res
    .status(200)
    .json(new ApiResponse(200, product, "Product fetched successfully"));
});
    
// Update Product
const updateProduct = asyncHandler(async (req, res) => {
  const { name, price, description } = req.body;
  const product = await Product.findById(req.params.id);

  if (!product) {
    throw new ApiError(404, "Product not found");
  }

  // If a new image is uploaded
  if (req.file) {
    // Delete old image from Cloudinary
    if (product.imagePublicId) {
      await cloudinary.uploader.destroy(product.imagePublicId);
    }

    // Upload new image
    const cloudinaryResult = await uploadOnCloudinary(req.file.path);
    if (!cloudinaryResult) {
      throw new ApiError(500, "Image upload failed");
    }

    product.imageUrl = cloudinaryResult.secure_url;
    product.imagePublicId = cloudinaryResult.public_id;
  }

  // Update fields if provided
  if (name) product.name = name;
  if (price) product.price = price;
  if (description) product.description = description;

  await product.save();

  return res
    .status(200)
    .json(new ApiResponse(200, product, "Product updated successfully"));
});


// Delete Product
const deleteProduct = asyncHandler(async (req, res) => {
  const product = await Product.findById(req.params.id);

  if (!product) {
    throw new ApiError(404, "Product not found");
  }

  // Delete image from Cloudinary
  if (product.imagePublicId) {
    await cloudinary.uploader.destroy(product.imagePublicId);
  }

  await product.deleteOne();

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "Product deleted successfully"));
});


export { createProduct, 
    getAllProducts, 
    getProductById, 
    updateProduct, 
    deleteProduct };
