import jwt from 'jsonwebtoken'

export default async function Profile (req ,res) {
    try{
        //get the token
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
     const token = authHeader.split(' ')[1]; // Remove "Bearer " prefix

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const userId = decoded.userID;
      const userEmail = decoded.email;
    

    const userName = dbInfo.name

       res.status(200).json({
      success: true,
      user: {
        id: userId,
        email: userEmail,
        name: userName, // Replace with actual user.name from DB
        avatar: "https://via.placeholder.com/80", // From DB
        ordersCount: 5, // From DB
        swappedCount: 3, // From DB
        itemsCount: 12 // From DB
      }
    });
    }catch (error) {
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