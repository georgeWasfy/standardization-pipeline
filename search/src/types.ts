export type Member = {
  id: string;
  name: string;
  first_name: string;
  last_name: string;
  title: string;
  url: string;
  hash: string;
  location: string;
  industry: string;
  summary: string;
  connections: string;
  recommendations_count: string;
  logo_url: string;
  last_response_code: null | number;
  created: string;
  last_updated: string;
  outdated: boolean;
  deleted: boolean;
  country: string;
  connections_count: null | number;
  experience_count: null | number;
  last_updated_ux: null | string;
  member_shorthand_name: string;
  member_shorthand_name_hash: string;
  canonical_url: string;
  canonical_hash: string;
  canonical_shorthand_name: string;
  canonical_shorthand_name_hash: string;
};

export type InsertMember = Omit<
  Member,
  | "id"
  | "created"
  | "last_response_code"
  | "last_updated"
  | "outdated"
  | "deleted"
  | "connections_count"
  | "experience_count"
  | "last_updated_ux"
>;

export type MemberArray = Member[];

export type MemberResponse = {
  data: MemberArray;
  paging: {
    total_count: number;
    page: number;
    per_page: number;
  };
};
