import mongoose from "mongoose";

let isConnected = false;

export default async function dbConnect() {
  if (mongoose.connection.readyState >= 1) return;

  try {
    const mongoUri = process.env.MONGODB_URI || process.env.MONGODB_ATLAS_URI || 'mongodb://127.0.0.1:27017/minds';
    await mongoose.connect(mongoUri);
    console.log("MongoDB connected successfully!");
  } catch (error) {
    console.error("MongoDB connection failed:", error);
    throw error;
  }
}