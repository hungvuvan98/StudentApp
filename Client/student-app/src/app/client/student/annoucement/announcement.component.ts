import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { AnnouncementModel } from './annoucement-model';
import { AnnouncementService } from './announcement.service';

@Component({
  selector: 'app-annoucement',
  templateUrl: './annoucement.component.html',
  styleUrls: ['./annoucement.component.css'],
  providers:[AnnouncementService]
})
export class AnnouncementComponent implements OnInit {

  studentId:string
  announcements:AnnouncementModel[]

  constructor(private authService : AuthService,
              private announService: AnnouncementService) { }

  ngOnInit(): void {
   this.authService.getUserId().subscribe(res=>{
     this.studentId=res
   })
    this.GetAllByStudent(this.studentId)
  }

 
  GetAllByStudent(id){
    this.announService.GetAllByStudent(id).subscribe(res=>{
      this.announcements=res
    })
  }
}