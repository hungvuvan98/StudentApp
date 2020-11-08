import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { StudentService } from '../student.service';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.css']
})
export class SidebarComponent implements OnInit {

  studentId:string
  student: any
  constructor(private authService: AuthService, private studentService: StudentService){}

  ngOnInit(): void {
    this.authService.getUserId().subscribe(res=>{
      this.studentId=res
      this.studentService.GetInfo(this.studentId).subscribe(res=>{
        this.student=res
    })
    })
  }

  Logout(){
    this.authService.logout()
  }

  show1 = true
  show2 = true
  show3 = true
  
  drop(data){
    if(data=='1'){
      if(this.show1==false) this.show1=true
      else this.show1=false
    }
    if(data=='2'){
      if(this.show2==false) this.show2=true
      else this.show2=false
    }
    if(data=='3'){
      if(this.show3==false) this.show3=true
      else this.show3=false
    }
    
  }

}
