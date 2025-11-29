import { Router } from 'express';

 //import addItem from '../Controllers/ItemRelated/addItem.js';

const itemsRoute = new Router();

    const connectAndAuth = async (req, res, next) => {
        // 1. Establish DB connection for this request
        const db = new Database(connectionString);
        req.db = db; // Attach the DB connection to the request object
        
        try {
            await db.sql("USE DATABASE Swapify");
            
            // --- Authentication ---
            const authHeader = req.headers.authorization;
            if (!authHeader || !authHeader.startsWith('Bearer ')) {
                throw new Error('No token provided');
            }
            
            const token = authHeader.split(' ')[1];
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            
            req.userId = decoded.userID; // Attach userId to the request for use in routes
            
            next(); // Proceed to the route handler
            
        } catch(e) {
            console.error("Auth/DB Connection Error:", e.message);
            
            // Ensure connection is closed on failure
            try { await db.close(); } catch (closeError) {}

            const status = e.message.includes('token') ? 401 : 500;
            return res.status(status).json({ 
                error: 'Authentication or Database connection failed.', 
                details: e.message 
            });
        }
    };

    itemsRoute.use(connectAndAuth)

itemsRoute.get('/get', async (req, res) => {

    const db = req.db;
    const userId = req.userId;

    try {
        // 1. Complex JOIN to retrieve all cart items and product details
        const getItemsSql = `
            SELECT 
                P.product_id, 
                P.product_name, 
                P.price, 
                P.owner AS product_owner_id,
                CI.quantity,
                C.cart_id
            FROM 
                Carts C
            INNER JOIN 
                Cart_Items CI ON C.cart_id = CI.cart_id
            INNER JOIN 
                Products P ON CI.product_id = P.product_id
            WHERE 
                C.user_id = '${userId}';
        `;
        
        const cartItems = await db.sql(getItemsSql);
    }catch(e){
        res.status(400).json({

        })
    }
});
//itemsRoute.post('/add', addItem);
// routes.put('/', SessionController.store);
// routes.delete('/', SessionController.store)

export  default itemsRoute;