import { Request, Response, NextFunction } from "express";
import Joi from "joi";

const memberSchema = Joi.object({
  name: Joi.string().trim().required(),
  first_name: Joi.string().trim().required(),
  last_name: Joi.string().trim().required(),
  title: Joi.string().trim().required(),
});

export function validateMember(req: Request, res: Response, next: NextFunction) {
  const { error } = memberSchema.validate(req.body, { abortEarly: false });

  if (error) {
    const messages = error.details.map((detail) => detail.message);
    return res.status(400).json({ errors: messages });
  }

  next();
}

