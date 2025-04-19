import { Router } from 'express';
import { MemberController } from '../../controllers/member.controller';

const router = Router();
const controller = new MemberController();
router.get('/members', controller.getAll);

export default router;
