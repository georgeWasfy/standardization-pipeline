import { Request, Response } from "express";
import { MemberRepository } from "../repositories/member.repository";
import { Filters, Paging } from "../utils/member.filters";

const memberRepo = new MemberRepository();

export class MemberController {
  async getAll(req: Request, res: Response) {
    try {
      const filters = (req.query.filters as Filters) || {};
      const paging = (req.query.paging as Paging) || {};
      const members = await memberRepo.getAll(filters, paging);
      res.json(members);
    } catch (err) {
      res.status(400).json({ error: "Failed to fetch members" });
    }
  }
}
