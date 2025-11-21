// to get env var
import dotenv from 'dotenv';
dotenv.config();

//database
import { Database } from "@sqlitecloud/drivers";
const connectionString = process.env.CONNECTION_STRING;

//Json web token - Auth
import jwt from 'jsonwebtoken'

const db = new Database(connectionString);


export default async function login(req, res) {
    const {email, password} = req.body;

    if (!email || !password) {
    return res.status(400).json({
      error: "Email and password are required"
    });
  }

    await db.sql(`USE DATABASE Swapify`)

   try{

    const existingUser = await db.sql(`
            SELECT userId, email, name FROM Users WHERE email = '${email}'`
        )

    console.log(existingUser)

    if(existingUser.length == 0){
         return res.status(400).json({
                error : "invalid credentials"
            })
    }

    const firstRow = existingUser[0]

    const token = jwt.sign(
        {userID : firstRow.userId , email : firstRow.email},
        process.env.JWT_SECRET,
        {expiresIn: "7d"}
    )

    res.status(200).json({
        message : "logged in successfully",
        token  : token,
        user : {
            name : firstRow.name,
            email : firstRow.email
        }
    })

   }catch(err){
    res.status(400).json({
        message : err
    })
   }
}