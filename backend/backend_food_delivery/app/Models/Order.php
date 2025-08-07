<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Order extends Model
{
    use HasFactory;

    protected $table = "orders";

    protected $fillable = [
        'user_id',
        'restaurant_id',
        'order_date',
        'total_price',
        'status',

    ];

    public function restaurant()
    {
        return $this->belongsTo(Restaurant::class, 'restaurant_id', 'id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }
}
