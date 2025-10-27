import { Router } from "express";

//controller
import Profile from "../Controllers/authControllers/Profile.auth.controller.js";

const profileRouter = Router()

profileRouter.get('/products', Profile)

export default profileRouter