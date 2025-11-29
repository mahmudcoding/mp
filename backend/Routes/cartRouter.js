import { Router } from "express";
import { Database } from '@sqlitecloud/drivers';
import jwt from 'jsonwebtoken'; 

// NOTE: Ensure process.env.CONNECTION_STRING and process.env.JWT_SECRET are set.
const connectionString = process.env.CONNECTION_STRING; 

const cartRouter = Router();

// --- Middleware to Connect DB and Authenticate User ---
// This function handles the repetitive tasks of connecting the DB and authenticating the user.
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

// --- Middleware to Close DB Connection ---
const closeDb = async (req, res, next) => {
    if (req.db) {
        try {
            await req.db.close();
        } catch (e) {
            console.error("Error closing DB connection:", e.message);
        }
    }
    next();
};

// Apply the common connection/auth logic to all cart routes
cartRouter.use(connectAndAuth);
// Apply the close logic after the request is handled
cartRouter.use(closeDb);


// =========================================================
// POST /add - ADD ITEM TO CART (Lazy Creation)
// =========================================================
cartRouter.post('/add', async (req, res) => {
    const db = req.db;
    const userId = req.userId;
    const { productId } = req.body; 

    try {
        if (!productId) {
            return res.status(400).json({ error: 'Product ID is required in the request body.' });
        }

        // 1. LAZY CREATE/UPSERT the Carts Table
        const upsertCartSql = `
            INSERT INTO Carts (user_id, created_at, updated_at) 
            VALUES ('${userId}', datetime('now'), datetime('now')) 
            ON CONFLICT(user_id) DO UPDATE 
            SET updated_at = datetime('now');
        `;
        await db.sql(upsertCartSql);

        // 2. Retrieve the Cart ID
        const getCartIdSql = `SELECT cart_id FROM Carts WHERE user_id = '${userId}'`;
        const cartResult = await db.sql(getCartIdSql);
        
        if (!cartResult || cartResult.length === 0) {
             throw new Error("Could not retrieve cart ID after creation.");
        }
        const cartId = cartResult[0].cart_id; 

        // 3. INSERT the Cart Item (ON CONFLICT increases quantity for simplicity)
        const insertItemSql = `
            INSERT INTO Cart_Items (cart_id, product_id, quantity) 
            VALUES ('${cartId}', '${productId}', 1)
            ON CONFLICT(cart_id, product_id) DO UPDATE
            SET quantity = quantity + 1;
        `;
        await db.sql(insertItemSql);

        return res.status(200).json({ 
            message: `Product ID ${productId} added/incremented in cart ${cartId}.`,
            cartId: cartId 
        });
        
    } catch(e) {
        console.error("Cart Add Error:", e.message);
        return res.status(500).json({ 
            error: 'Failed to add item to cart.', 
            details: e.message 
        });
    }
});


// =========================================================
// DELETE /remove - REMOVE ITEM FROM CART
// =========================================================
cartRouter.delete('/remove/:productId', async (req, res) => {
    const db = req.db;
    const userId = req.userId;
    const { productId } = req.params; 

    try {
        if (!productId) {
            return res.status(400).json({ error: 'Product ID is required in the URL parameter.' });
        }
        
        // 1. Retrieve the Cart ID
        const getCartIdSql = `SELECT cart_id FROM Carts WHERE user_id = '${userId}'`;
        const cartResult = await db.sql(getCartIdSql);
        
        if (!cartResult || cartResult.length === 0) {
            return res.status(404).json({ message: "Cart not found for this user." });
        }
        const cartId = cartResult[0].cart_id; 

        // 2. Delete the Item from Cart_Items
        const deleteItemSql = `
            DELETE FROM Cart_Items 
            WHERE cart_id = '${cartId}' 
              AND product_id = '${productId}';
        `;
        const deleteResult = await db.sql(deleteItemSql);

        // NOTE: In SQLite, there is no direct way to get rows affected easily in this driver context.
        // We assume the deletion was successful if no error occurred.

        // 3. Update Cart Timestamp
        const updateCartSql = `
            UPDATE Carts 
            SET updated_at = datetime('now') 
            WHERE cart_id = '${cartId}';
        `;
        await db.sql(updateCartSql);

        return res.status(200).json({ 
            message: `Product ID ${productId} removed from cart ${cartId}.`
        });
        
    } catch(e) {
        console.error("Cart Remove Error:", e.message);
        return res.status(500).json({ 
            error: 'Failed to remove item from cart.', 
            details: e.message 
        });
    }
});


// =========================================================
// GET /items - GET ALL CART OBJECTS
// =========================================================
cartRouter.get('/items', async (req, res) => {
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

        if (!cartItems || cartItems.length === 0) {
            return res.status(200).json({ 
                message: "Cart is empty.",
                items: []
            });
        }

        // Success response with the list of items
        return res.status(200).json({ 
            message: `Found ${cartItems.length} items in cart.`,
            items: cartItems 
        });
        
    } catch(e) {
        console.error("Get Cart Items Error:", e.message);
        return res.status(500).json({ 
            error: 'Failed to retrieve cart items.', 
            details: e.message 
        });
    }
});

export default cartRouter;