import db from "../config/db";
import { InsertMember, MemberResponse } from "../types";
import { Filters, Paging } from "../middlewares/member.filters";

export class MemberRepository {
  async getAll(filters?: Filters, paging?: Paging): Promise<MemberResponse> {
    const baseQuery = db("member").join(
      "standardized_title",
      "member.title",
      "standardized_title.job_title"
    );

    if (filters) {
      if (filters.department) {
        baseQuery.whereRaw("LOWER(standardized_title.job_department) = LOWER(?)", [
          filters.department,
        ]);
      }
      if (filters.function) {
        baseQuery.whereRaw("LOWER(standardized_title.job_function) = LOWER(?)", [filters.function]);
      }
      if (filters.seniority) {
        baseQuery.whereRaw("LOWER(standardized_title.job_seniority) = LOWER(?)", [
          filters.seniority,
        ]);
      }
    }

    const countQuery = baseQuery.clone().count<{ count: string }>("member.id as count").first();

    const page = paging?.page && paging.page > 0 ? paging.page : 1;
    const perPage = paging?.per_page && paging.per_page > 0 ? paging.per_page : 10;

    const countResult = await countQuery;
    const total_count = countResult ? parseInt(countResult.count, 10) : 0;

    const data = await baseQuery
      .clone()
      .select(
        "member.*",
        "standardized_title.job_department",
        "standardized_title.job_function",
        "standardized_title.job_seniority"
      )
      .limit(perPage)
      .offset((page - 1) * perPage);

    return {
      data,
      paging: {
        total_count,
        page,
        per_page: perPage,
      },
    };
  }

  async insertMember(data: InsertMember) {
    return db("member").insert(data);
  }
}
