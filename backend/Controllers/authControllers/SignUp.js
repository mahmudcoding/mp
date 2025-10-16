import User from '../../models/User.js'
import {User as UserAssoc} from '../../models/associations.js'


export default async function signup(req, res) {
    try{
    const UserData = req.body

    const addUser = await User.create(UserData)

    res.status(200).json(addUser)


    }catch(err){
        res.status(500).json({
            "err" : "Something wrong with signup"
        })
    }
}