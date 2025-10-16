import express from 'express'
import dotenv from 'dotenv'
import morgan from 'morgan'
import cors from 'cors'

//router
import authRouter from './Routes/authRoutes.js'
import cartRouter from './Routes/cartRouter.js'

//Dotenv config - enables taking keys from .env file
dotenv.config()

//Entry point to backend
const app = express()

//middlewares
app.use(morgan())
app.use(cors())
app.use(express.json())

//Endpoints
app.use('/api/auth' , authRouter)
app.use('/api/cart' , cartRouter)

//app starts
app.listen(3000 , ()=>{
    console.log(`listening to ${3000}`)
})