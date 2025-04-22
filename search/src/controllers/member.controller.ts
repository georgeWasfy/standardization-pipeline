import { Request, Response } from "express";
import { MemberRepository } from "../repositories/member.repository";
import { Filters, Paging } from "../middlewares/member.filters";
import { InsertMember, Member } from "../types";

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

  async createMember(req: Request, res: Response) {
    try {
      const { name, first_name, last_name, title } = req.body;

      const defaultValues = {
        url: "https://example.com",
        hash: "somehashvalue",
        location: "New York",
        industry: "Software",
        summary: "Experienced software engineer",
        connections: "150",
        recommendations_count: "25",
        logo_url: "https://example.com/logo.png",
        country: "USA",
        member_shorthand_name: "J.Doe",
        member_shorthand_name_hash: "hashvalue",
        canonical_url: "https://example.com/canonical",
        canonical_hash: "canonicalhashvalue",
        canonical_shorthand_name: "Canonical J.Doe",
        canonical_shorthand_name_hash: "canonicalhashvalue",
      };

      const newMember: InsertMember = {
        name,
        first_name,
        last_name,
        title,
        ...defaultValues,
      };

      await memberRepo.insertMember(newMember);
      res.status(201).json({ message: "Member inserted successfully" });
    } catch (error) {
      console.error("Error inserting member:", error);
      res.status(500).json({ error: "Internal server error" });
    }
  }
}
