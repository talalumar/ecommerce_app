import multer from 'multer';
import path from 'path';

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, './public/temp')
  },
  filename: function (req, file, cb) {
    // Generate unique filename
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);

    // Get extension (e.g., .jpg, .png)
    const ext = path.extname(file.originalname);

    // Final file name: image-163534534.png
    cb(null, file.fieldname + "-" + uniqueSuffix + ext);
  },
})

export const upload = multer({ storage, }) 