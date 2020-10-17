import { Component, OnInit } from '@angular/core';

declare interface RouteInfo {
    path: string;
    title: string;
    icon: string;
    class: string;
}
export const ROUTES: RouteInfo[] = [
     { path: '/admin/homepage', title: 'Home',  icon:'fa fa-home', class: '' },
    { path: '/admin/student', title: 'Sinh vien',  icon:'fa fa-users', class: '' },
    // { path: '/admin/feedback', title: 'Thoi khoa bieu',  icon:'fa fa-users', class: '' },// dropdown of student
    { path: '/admin/instructor', title: 'Giang vien',  icon:'fa fa-users', class: '' },
    { path: '/admin/class-list', title: 'DS lớp mở kì này',  icon:'fa fa-users', class: '' },
    { path: '/admin/department', title: 'Khoa vien',  icon:'fa fa-users', class: '' },
    { path: '/admin/post', title: 'Bai viet',  icon:'fa fa-users', class: '' },
    { path: '/admin/postcategory', title: 'Post Category',  icon:'fa fa-users', class: '' },
    { path: '/admin/feedback', title: 'Phan hoi',  icon:'fa fa-users', class: '' },

];

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.css']
})
export class SidebarComponent implements OnInit {
  menuItems: any[];

  constructor() { }

  ngOnInit() {
    this.menuItems = ROUTES.filter(menuItem => menuItem);
  }
  isMobileMenu() {
      if ( window.innerWidth > 991) {
          return false;
      }
      return true;
  };
}
