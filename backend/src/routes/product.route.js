import express from "express";
import { createProduct,
     getAllProducts,
     getProductById,
     updateProduct,
     deleteProduct
     } from "../controllers/product.controller.js";
import { upload } from "../middlewares/multer.middleware.js";

const router = express.Router();

router.post("/", upload.single("imageFile"), createProduct);
router.get("/get", getAllProducts);
router.get("/get/:id", getProductById);
router.put("/update/:id", upload.single("imageFile"), updateProduct);
router.delete("/delete/:id", deleteProduct);

export default router;
