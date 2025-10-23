import { Router } from "express";

//controllers
import addItemCart from '../Controllers/CartControllers/Add.Cart.js'
import buyIteamCart from '../Controllers/CartControllers/Buy.Cart.js'
import deleteItemCart from '../Controllers/CartControllers/Delete.Cart.js'

const cartRouter = Router()

cartRouter.post('/add', addItemCart)
cartRouter.get('/buy', buyIteamCart)
cartRouter.delete('/delete', deleteItemCart)

export default cartRouter