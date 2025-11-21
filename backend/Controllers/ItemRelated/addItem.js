import dotenv from 'dotenv'
dotenv.config()
const connectionString = process.env.CONNECTION_STRING

export default async function addItem(req, res) {
     
    const {product_name, price, owner } = req.body
    const headers = req.body.authorization

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'No token provided' });
        }
 try{
    const token = authHeader.split(' ')[1]; // Remove "Bearer " prefix
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const userID = decoded.userID;
    const userEmail = decoded.email;

    await db.sql('USE DATABASE Swapify')

    const addValue = await db.sql(`
        INSERT INTO products (product_name, price, owner)
        VALUES ('${product_name}', ${price}, ${owner})
        `)

    if(addValue.changes > 0){
        res.status(200).json({
            message: "Item Added Successfully"
        })
    }else{
        res.status(200).json({
            message: "Item Added Unsuccessfully"
        })
    }
    }catch(e){
        console.log(e)
    }
}