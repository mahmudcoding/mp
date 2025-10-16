import express from 'express'
import dotenv from 'dotenv'
import morgan from 'morgan'
import cors from 'cors'

//db
import { sequelize } from './models/database.js';
import { User, Product } from './models/associations.js';

//router
import authRouter from './Routes/authRoutes.js'
import cartRouter from './Routes/cartRouter.js'

//Dotenv config - enables taking keys from .env file
dotenv.config()

//Entry point to backend
const app = express()

//db connection
sequelize.sync({ force: false })
  .then(() => console.log('Database synced'))
  .catch(err => console.log('Sync error: ', err));


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