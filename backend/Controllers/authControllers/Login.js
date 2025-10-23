//database
import User from '../../models/User.js'
import {User as UserAssoc} from '../../models/associations.js'

//Json web token - Auth
import jwt from 'jsonwebtoken'


export default async function login(req, res) {
    const {email, password} = req.body;

    if (!email || !password) {
    return res.status(400).json({
      error: "Email and password are required"
    });
  }

   try{

    const existingUser = await UserAssoc.findOne({
        where : {
            email : email,
            password : password
        }
    })

    if(!existingUser){
        return res.status(400).json({
            error : "invalid credentials"
        })
    }


    const token = jwt.sign(
        {userID : existingUser.id , email : existingUser.email},
        process.env.JWT_SECRET,
        {expiresIn: "7d"}
    )

    res.status(200).json({
        messafe : "logged in successfully",
        token  : token,
        user : {
            name : existingUser.name,
            email : existingUser.email
        }
    })

   }catch(err){
    res.status(400).json({
        message : err
    })
   }
}