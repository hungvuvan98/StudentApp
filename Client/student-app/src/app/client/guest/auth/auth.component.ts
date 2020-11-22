import { Component, OnInit, ViewChild } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../shared/services/auth/auth.service';

@Component({
  selector: 'app-auth',
  templateUrl: './auth.component.html',
  styleUrls: ['./auth.component.css'],
})
export class AuthComponent implements OnInit {

  loginForm: FormGroup
  isAdmin = false
  siteKey:string
  constructor(private fb: FormBuilder, private authService: AuthService, private route: Router) {
    this.siteKey = '6Ldhk-cZAAAAADlY8rhAjyjSUPOY2fPfCmkkZkG3';
    this.loginForm = this.fb.group({
      id: ['',Validators.required],
      password: ['', Validators.required],
      recaptcha: ['',Validators.required] 
    });
  }

  ngOnInit() {
   
  }

  handleSuccess(data) {
    console.log(data);
  }
  login(){
    if(this.isAdmin===false){
      this.authService.login(this.loginForm.value).subscribe(data=>{
        this.authService.saveToken(data['token'])
        this.route.navigate(['student'])
      })
    }
    else if(this.isAdmin===true){
      this.authService.login(this.loginForm.value).subscribe(data=>{
        this.authService.saveToken(data['token']);
        this.route.navigate(['admin']);    
      });
     // console.log('true')
    }
  }

  get userId() { return this.loginForm.get('id')}

  get password() { return this.loginForm.get('password')}  

 
}
