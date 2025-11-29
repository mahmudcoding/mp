// to get env var
import dotenv from 'dotenv';
dotenv.config();

// database operations
import { Database } from "@sqlitecloud/drivers";
const connectionString = process.env.CONNECTION_STRING;
// Json web token
import jwt from 'jsonwebtoken';

// Initialize database connection
const db = new Database(connectionString);

export default async function signup(req, res) {
    // Check if it's POST request
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const UserData = req.body;

    console.log('UserData received:', UserData);
    console.log('Name:', UserData.name, 'Type:', typeof UserData.name);
    console.log('Email:', UserData.email, 'Type:', typeof UserData.email);
    console.log('Password:', UserData.password ? '***' : 'undefined', 'Type:', typeof UserData.password);

    // Validate required fields
    if (!UserData.name || !UserData.email || !UserData.password) {
        return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    try {
        // Use database first
        await db.sql(`USE DATABASE Swapify`);

        // Check if user already exists - with case-insensitive check
        const existingUser = await db.sql(
            `SELECT userId, email FROM users WHERE LOWER(email) = LOWER('${UserData.email}')`
        );

        // Check if any user with this email exists
        if (existingUser.rows && existingUser.rows.length > 0) {
            console.log('❌ User already exists with email:', UserData.email);
            return res.status(409).json({ error: "User already exists" });
        }

        console.log('✅ No existing user found, creating new user...');

        // Create new user
        const result = await db.sql(
            `INSERT INTO users (name, email, password) VALUES ('${UserData.name}', '${UserData.email}', '${UserData.password}')`
        );

            console.log('✅ User inserted successfully, retrieving user data...');
            
            const newUser = await db.sql(
                `SELECT userId, name, email FROM users WHERE email = '${UserData.email}'`
            );

            const user = newUser[0];

                const token = jwt.sign(
                    { userID: user.userId, email: user.email }, 
                    process.env.JWT_SECRET, 
                    { expiresIn: "7d" }
                );

                return res.status(200).json({
                    message: "User created successfully",
                    token: token,
                    user: {
                        userId: user.userId, // Include userId in response
                        name: user.name,
                        email: user.email,
                    }
                });
    } catch (err) {
        console.error("❌ Signup error:", err);
        
        // Handle specific errors
        if (err.message.includes('UNIQUE constraint failed')) {
            return res.status(409).json({ 
                error: "User already exists",
                details: "An account with this email already exists" 
            });
        }
        
        if (err.message.includes('USE DATABASE')) {
            return res.status(500).json({ 
                error: "Database error",
                details: "Could not select database" 
            });
        }
        
        return res.status(500).json({
            error: "Something went wrong with signup",
            details: err.message
        });
    }
}