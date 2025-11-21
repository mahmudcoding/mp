import { Router } from "express";

//controller
import Profile from "../Controllers/authControllers/Profile.auth.controller.js";

const personalData = Router()

personalData.get('/products', Profile)

export default personalData