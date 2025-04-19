import { Request, Response, NextFunction } from "express";
import qs from "qs";

export interface Filters {
  department?: string;
  function?: string;
  seniority?: string;
  [key: string]: any;
}

export interface Paging {
  page?: number;
  per_page?: number;
}

interface ParsedQuery {
  filters?: Filters;
  paging?: Paging;
  [key: string]: any;
}

export function parseAndNormalizeQuery(req: Request, res: Response, next: NextFunction) {
  const url = new URL(req.originalUrl, "http://localhost");
  const rawQuery = url.searchParams.toString();
  const parsed = qs.parse(rawQuery) as ParsedQuery;

  // Normalize paging parameters to numbers if present
  if (parsed.paging) {
    if (parsed.paging.page) {
      parsed.paging.page = Number(parsed.paging.page);
      if (isNaN(parsed.paging.page)) parsed.paging.page = undefined;
    }
    if (parsed.paging.per_page) {
      parsed.paging.per_page = Number(parsed.paging.per_page);
      if (isNaN(parsed.paging.per_page)) parsed.paging.per_page = undefined;
    }
  }

  // Attach normalized query to request
  req.query = parsed;

  next();
}
