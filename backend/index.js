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
app.use(morgan('dev'))
app.use(cors())
app.use(express.json())

//Endpoints
app.use('/api/auth' , authRouter)
app.use('/api/cart' , cartRouter)

//app starts
sequelize.sync()
  .then(() => {
    console.log('Database synced successfully!');
    app.listen(3000, () => {
      console.log('Server is running on http://localhost:3000');
    });
  })
  .catch((err) => {
    console.error('Error syncing database:', err);
  });