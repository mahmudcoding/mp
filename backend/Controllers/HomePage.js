import dotenv from 'dotenv'
import { Database } from "@sqlitecloud/drivers";
const connectionString = process.env.CONNECTION_STRING;

const db = new Database(connectionString)

export default async function homePage(req , res) {

    await db.sql(`USE DATABASE Swapify`)

    const eightProducts = await db.sql(`
        SELECT 
            p.*,
            u.name as owner_name,
            u.email as owner_email
        FROM products p
        JOIN users u ON p.owner = u.userId
        ORDER BY p.product_id DESC
        LIMIT 8;
        `)

    console.log(eightProducts)

    const product1 = eightProducts[0];
    const product2 = eightProducts[1];
    const product3 = eightProducts[2];
    const product4 = eightProducts[3];
    const product5 = eightProducts[4];
    const product6 = eightProducts[5];
    const product7 = eightProducts[6];
    const product8 = eightProducts[7];
    

    res.status(200).json({
        message : "Products taken",
        products: {
            product1 : {
                name : product1.product_name,
                price: product1.price,
                owner : product1.owner_name,
                owner_email : product1.owner_email
            },
            product2 : {
                name : product2.product_name,
                price: product2.price,
                owner : product2.owner_name,
                owner_email : product2.owner_email
            },
            product3 : {
                name : product3.product_name,
                price: product3.price,
                owner : product3.owner_name,
                owner_email : product3.owner_email
            },
            product4 : {
                name : product4.product_name,
                price: product4.price,
                owner : product4.owner_name,
                owner_email : product4.owner_email
            },
            product5 : {
                name : product5.product_name,
                price: product5.price,
                owner : product5.owner_name,
                owner_email : product5.owner_email
            },
            product6 : {
                name : product6.product_name,
                price: product6.price,
                owner : product6.owner_name,
                owner_email : product6.owner_email
            },
            product7 : {
                name : product7.product_name,
                price: product7.price,
                owner : product7.owner_name,
                owner_email : product7.owner_email
            },
            product8 : {
                name : product8.product_name,
                price: product8.price,
                owner : product8.owner_name,
                owner_email : product8.owner_email
            },
        }

    })


}