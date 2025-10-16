import { Router } from "express";
import { validateUser } from "../middleware/user.validation.js";

//Controllers
import login from '../Controllers/authControllers/Login.js'
import signup from '../Controllers/authControllers/SignUp.js'

const authRouter = Router()

//Auth
authRouter.post('/login', login)
authRouter.post('/signup', validateUser , signup)


export default authRouter