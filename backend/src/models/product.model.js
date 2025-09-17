import mongoose from "mongoose";

const productSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Product name is required"],
      trim: true,
    },
    price: {
      type: Number,
      required: [true, "Product price is required"],
      min: [0, "Price must be a positive number"],
    },
    description: {
      type: String,
      required: [true, "Product description is required"],
    },
    imageUrl: {
      type: String, // Cloudinary URL
      required: [true, "Product image is required"],
    },
    imagePublicId: {
      type: String, // Cloudinary public_id for future deletion
    },
  },
  { timestamps: true }
);

export const Product = mongoose.model("Product", productSchema);
