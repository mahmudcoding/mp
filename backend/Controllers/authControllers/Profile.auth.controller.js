import jwt from 'jsonwebtoken'
import { Database } from '@sqlitecloud/drivers';

const connectionString = process.env.CONNECTION_STRING; 

export default async function Profile(req, res) {
    const db = new Database(connectionString);

    try {
        await db.sql("USE DATABASE Swapify");
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            await db.close(); 
            return res.status(401).json({ error: 'No token provided' });
        }
        
        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        const userId = decoded.userID;
        const userEmail = decoded.email;

        console.log(userId);
        console.log(userEmail);

        
        // FIX 1: Use parameterized query for safety and consistency
        const userProducts = await db.sql(
            `SELECT p.product_name, p.price
            FROM Users u
            JOIN products p ON u.userId = p.owner
            WHERE u.userId = '${userId}'`
        );

        // FIX 1: Use parameterized query
        const userNameResult = await db.sql(
            `SELECT name from Users WHERE userId = '${userId}'`
        );

        // FIX 2: Extract the actual name string from the result array
        const userName = userNameResult.length > 0 ? userNameResult[0].name : null;


        if (userProducts.length === 0) {
            console.log("no user or no products");
        }

        // FIX 5: Change the response structure to match what Flutter expects (user object)
        res.status(200).json({
            success: true, 
            // Return data inside a 'user' object for Flutter consistency
            user: { 
                name: userName,
                email: userEmail
            },
            products: userProducts
        });
       
    } catch (error) {
        // FIX 6: Use the safer db.close() pattern
        if (db && typeof db.close === 'function') {
            try {
                await db.close();
            } catch (closeError) {
                console.error("Failed to close DB connection:", closeError);
            }
        }
        
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ error: 'Invalid token' });
        }
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({ error: 'Token expired' });
        }
        
        console.error('Profile error:', error);
        res.status(500).json({ error: 'Server error' });
    }
}