import mongoose from "mongoose";

export default async function dbConnect() {
  if (mongoose.connection.readyState >= 1) return;

  // Skip connecting during Next.js build
  if (process.env.NEXT_PHASE === 'phase-production-build' || process.env.BUILDING === 'true') {
    return;
  }

  const mongoUri = process.env.MONGODB_URI || process.env.MONGODB_ATLAS_URI || 'mongodb://127.0.0.1:27017/minds';
  if (!mongoUri) {
    console.warn("MongoDB URI not provided");
    return;
  }

  try {
    await mongoose.connect(mongoUri);
    console.log("MongoDB connected successfully!");
  } catch (error) {
    console.error("MongoDB connection failed:", error.message || error);
    if (process.env.NEXT_PHASE !== 'phase-production-build') {
      throw error;
    }
  }
}