import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { NotificationService } from '../../../shared/services/Notification/Notification.service';

@Component({
  selector: 'app-change-password',
  templateUrl: './change-password.component.html',
  styleUrls: ['./change-password.component.css']
})
export class ChangePasswordComponent  {

  changePasswordForm: FormGroup
  constructor(private fb: FormBuilder,private auth:AuthService,private noticeService:NotificationService) { 
    this.changePasswordForm = this.fb.group({
      oldPassword: ['', Validators.required],
      newPassword:['',Validators.required]
    })
  }
  changPassword() {
    this.auth.changPassword(this.changePasswordForm.value).subscribe(res => {
      console.log(res)
      if (res == 1) {
        this.noticeService.show("success", "Đổi mật khẩu thành công!"); 
        this.auth.logout();
      }

    })
  }

  get oldPass() { return this.changePasswordForm.get('oldPassword')}

  get newPass() { return this.changePasswordForm.get('newPassword')}  
}
