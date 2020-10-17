import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../../common/services/auth/auth.service';
import { AnnouncementService } from '../../services/annoucement.service';
import { Announcement } from '../../models/announcement';

@Component({
  selector: 'app-notification',
  templateUrl: './notification.component.html',
  styleUrls: ['./notification.component.css'],
  providers:[AnnouncementService]
})
export class NotificationComponent implements OnInit {

  studentId:string
  announcements:Announcement[]

  constructor(private authService : AuthService,
              private announService: AnnouncementService) { }

  ngOnInit(): void {
    this.studentId=this.authService.getStudentId()
    this.GetAllByStudent(this.studentId)
  }

  GetAllByStudent(id){
    this.announService.GetAllByStudent(id).subscribe(res=>{
      this.announcements=res
    })
  }
}
