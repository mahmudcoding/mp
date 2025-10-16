//database operations
import User from '../../models/User.js'
import {User as UserAssoc} from '../../models/associations.js'

//Json web token
import jwt from 'jsonwebtoken'

//to get env var
import dotenv from 'dotenv'
dotenv.config()


export default async function signup(req, res) {
    const UserData = req.body

    try{

    const isExists = await  UserAssoc.findOne({
        where : {
            email : UserData.email
        }
    })

    if(isExists){
        return res.status(401).json("User already exists")
    }

    const newUser = await User.create(UserData)

    const token = jwt.sign({userID : newUser.id , email : newUser.email}, process.env.JWT_SECRET, {expiresIn : "7d"})

    res.status(200).json({
        message : "User created successfully",
        token : token,
        user : {
            name : newUser.name,
            email : newUser.email,
        }
    })


    }catch(err){
        res.status(500).json({
            "err" : "Something wrong with signup"
        })
    }
}