import { Router } from 'express';

 import addItem from '../Controllers/ItemRelated/addItem.js';

const itemsRoute = new Router();

// Add routes
// routes.get('/', SessionController.store);
itemsRoute.post('/add', addItem);
// routes.put('/', SessionController.store);
// routes.delete('/', SessionController.store)

export  default itemsRoute;