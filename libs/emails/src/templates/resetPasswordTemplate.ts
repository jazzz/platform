import { DEFAULT_EMAIL } from '../email.consts'
import { EmailTemplate } from './emailTemplate'

export class ResetPasswordTemplate implements EmailTemplate {
  name = 'ResetPassword'
  sendFrom = DEFAULT_EMAIL

  constructor(private readonly username: string, private readonly resetPasswordCode: string) {}

  getSubject(): string {
    return 'Reset your password for ChainJet'
  }

  getTextBody(): string {
    return ''
  }

  getHtmlBody(): string {
    return `Hello ${this.username},<br/><br/>
    
    Follow this link to reset your password:
    ${process.env.FRONTEND_ENDPOINT}/login/password-reset?username=${this.username}&code=${this.resetPasswordCode}<br/><br/>
    
    If you didn't ask to reset your password, please ignore this email.<br/><br/>
    
    Thanks,<br/>
    ChainJet team.`
  }
}
