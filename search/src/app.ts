import express from "express";
import memberRoutes from "./routes/v1/member.route";
import { parseAndNormalizeQuery } from "./middlewares/member.filters";

const app = express();

app.use(express.json());
app.use(parseAndNormalizeQuery);

app.use("/api/v1", memberRoutes);

export default app;
