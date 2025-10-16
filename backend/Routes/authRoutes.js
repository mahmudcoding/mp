import { Router } from "express";

//Controllers
import login from '../Controllers/authControllers/Login.js'
import signup from '../Controllers/authControllers/SignUp.js'

const authRouter = Router()

//Auth
authRouter.post('/login', login)
authRouter.post('/signup', signup)


export default authRouter