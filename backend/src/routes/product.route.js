import express from "express";
import { createProduct,
     getAllProducts,
     getProductById,
     updateProduct,
     deleteProduct
     } from "../controllers/product.controller.js";
import { upload } from "../middlewares/multer.middleware.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { isAdmin } from "../middlewares/isAdmin.middleware.js";

const router = express.Router();

router.use(verifyJWT); // Protect all routes below this middleware
router.get("/get", getAllProducts);
router.get("/get/:id", getProductById);
 
router.use(isAdmin); // Only admin can access routes below this middleware
router.post("/add", upload.single("imageFile"), createProduct);
router.put("/update/:id", upload.single("imageFile"), updateProduct);
router.delete("/delete/:id", deleteProduct); 

export default router;

