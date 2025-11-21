import jwt from 'jsonwebtoken'
import { Database } from '@sqlitecloud/drivers';
import dotenv from 'dotenv'
import { use } from 'react';
dotenv.config()
const connectionString = process.env.CONNECTION_STRING

<<<<<<< HEAD
import { Database } from "@sqlitecloud/drivers";
const connectionString = process.env.CONNECTION_STRING;

const db = new Database(connectionString);

export default async function Profile (req ,res) {
    try{
      await db.sql(`USE DATABASE Swapify`);
=======
export default async function Profile (req, res) {
    const db = new Database(connectionString)
    try {
>>>>>>> backend
        //get the token
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'No token provided' });
        }
        
        const token = authHeader.split(' ')[1]; // Remove "Bearer " prefix
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        const userID = decoded.userID;
        const userEmail = decoded.email;
        console.log(userID)
        console.log(userEmail)

<<<<<<< HEAD
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const userId = decoded.userID;
      const userEmail = decoded.email;

      const dbInfo = await db.sql(
            `SELECT name FROM users WHERE LOWER(email) = LOWER('${userEmail}')`
        );
    
=======
        await db.sql('USE DATABASE Swapify')
>>>>>>> backend

        async function fetchData() {
            return await db.sql(
                `SELECT p.product_name, p.price, u.name
                FROM Users u
                JOIN products p ON u.userId = p.owner
                WHERE u.userId = '${userID}'`
            );
        }

        // Wait for the data to be fetched
        const userData = await fetchData();
        console.log(userData);
        const productsArray = [];

        if (userData.length === 0) {
          console.log("no user or nor products");
            return res.status(404).json({ 

                error: 'User not found or no products' 
            });
        }
        
        const firstRow = userData[0]


        
        // Process the data
        for(let index = 0; index < userData.length; index++) {
            let element = userData[index];
            productsArray.push({
                product_name: element.product_name,
                price: element.price
            });
        }

        console.log(userData);
        
        res.status(200).json({
            success: true, 
            user: { 
                email: userEmail,
                name: firstRow.name, 
                avatar: "https://via.placeholder.com/80",
                itemsCount: userData.length,
            },
            products: productsArray 
        });
       
    } catch (error) {
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