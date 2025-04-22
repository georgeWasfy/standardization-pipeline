import { Router } from "express";
import { MemberController } from "../../controllers/member.controller";
import { validateMember } from "../../middlewares/member.validation";
const router = Router();
const controller = new MemberController();
router.get("/members", controller.getAll);
router.post("/member", validateMember, controller.createMember);
export default router;
