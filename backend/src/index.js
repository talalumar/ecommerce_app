import dotenv from "dotenv"
import connectDB from "./db/index.js"
import {app} from "./app.js"

dotenv.config({path: './.env'})
 


connectDB()
.then(() => {

    const port = process.env.PORT || 5000;

    app.on("error", (error) => {
            console.log("Error: ", error);
            throw error
    })

    app.listen(port, "0.0.0.0", () => {
        console.log(`Server is running at port  : ${port}`);
    })
})
.catch((err) => console.log(`MongoDB connection error: ${err}`))