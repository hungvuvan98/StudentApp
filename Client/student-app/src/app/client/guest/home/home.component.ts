import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { HomeService } from './home.service';


@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css'],
  providers:[HomeService]
})
export class HomeComponent implements OnInit {

  loginForm: FormGroup;
  isAdmin = false;
  siteKey: string
  listPost: any[];
  config: any
  
  constructor(private fb: FormBuilder, private authService: AuthService, private route: Router,private modalService: NgbModal,private homeService:HomeService) {
    
    this.siteKey = '6Ldhk-cZAAAAADlY8rhAjyjSUPOY2fPfCmkkZkG3';
    this.loginForm = this.fb.group({
      id: ['',Validators.required],
      password: ['', Validators.required],
      recaptcha: ['',Validators.required] 
    });
    this.PageAction(event);
  }
  ngOnInit(): void {
    this.getPostByCategory(0);
  }

  getPostByCategory(categoryId) {
    this.homeService.getPostByCategory(categoryId).subscribe(data => {
      this.listPost = data;
    })
  }

  handleSuccess(data) {
    console.log(data);
  }
  login(){
    if(this.isAdmin===false){
      this.authService.login(this.loginForm.value).subscribe(data=>{
        this.authService.saveToken(data['token'])
        this.modalService.dismissAll();
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

  openLg(content) {
    this.modalService.open(content);
  }

  PageAction(event){
    this.config = {
      itemsPerPage: 3,
      currentPage: 1,
      totalItems: this.listPost?.length
    }
    // call if page changed
    this.config.currentPage = event
  }
}
