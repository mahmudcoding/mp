import { Router } from "express"

import homePage from "../Controllers/HomePage.js";

const homePageRouter = Router() //instance of Router

homePageRouter.get('/products' , homePage)

export default homePageRouter;