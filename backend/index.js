import express from 'express'
import dotenv from 'dotenv'
import morgan from 'morgan'
import cors from 'cors'

//router
import authRouter from './Routes/authRoutes.js'
import profileRouter from './Routes/personalData.js'
import itemsRoute from './Routes/itemsRouter.js'
import cartRouter from './Routes/cartRouter.js'

//Dotenv config - enables taking keys from .env file
dotenv.config()

//Entry point to backend
const app = express()


//middlewares
app.use(morgan('dev'))
app.use(cors())
app.use(express.json())

// Simple test endpoint
app.get('/', (req, res) => {
    res.json({ message: "Hello world" }); // Fixed: res.json() not res.message()
})

// Routes
app.use('/api/auth', authRouter)
app.use('/cart', cartRouter)
app.use('/api/profile', profileRouter)
//app.use('/api/homePage', homePageRouter)
app.use('/products', itemsRoute)

const Port = 3001;

app.listen(Port, '0.0.0.0', () => {
    console.log(`Server is running on http://192.168.100.99:${Port}`);
    console.log(`Also accessible on http://localhost:${Port}`);
    console.log('✅ Server started successfully!');
});